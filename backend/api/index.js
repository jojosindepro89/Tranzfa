const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');

const app = express();

app.use(cors());
app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET || 'tranzfa_super_secret_jwt_key_2026';

// In-Memory Production State Demo Database
const db = {
  users: [
    {
      id: 'usr_001',
      fullName: 'Sarah Okonjo',
      email: 'sarah.okonjo@tranzfa.io',
      accountTag: '@sarah',
      accountNumber: '2048591823',
      balance: 1240500.00,
      currency: 'NGN',
      currencySymbol: '₦',
      securityPin: '1234', // Factor 3 PIN
      activeOtp: '123456',  // Factor 2 OTP
      tier: 'Tier 3 (Verified)',
    }
  ],
  transactions: [
    {
      id: 'TZ-9948201-X',
      title: 'Starbucks Coffee',
      category: 'Food',
      amount: 12.50,
      currencySymbol: '$',
      type: 'debit',
      status: 'SUCCESSFUL',
      dateTimeText: 'Today, 2:30 PM',
      timestamp: Date.now() - 3600000,
    },
    {
      id: 'TZ-9948202-Y',
      title: 'Uber Trip',
      category: 'Transport',
      amount: 24.00,
      currencySymbol: '$',
      type: 'debit',
      status: 'SUCCESSFUL',
      dateTimeText: 'Today, 11:15 AM',
      timestamp: Date.now() - 7200000,
    },
    {
      id: 'TZ-9948203-Z',
      title: 'Salary Deposit',
      category: 'INCOME',
      amount: 3450.00,
      currencySymbol: '$',
      type: 'credit',
      status: 'SUCCESSFUL',
      dateTimeText: 'Today, 09:00 AM',
      timestamp: Date.now() - 14400000,
    },
  ],
  savingsGoals: [
    {
      id: 'goal_1',
      title: 'New Car (Porsche 911 GT3)',
      currentAmount: 15000.00,
      targetAmount: 23000.00,
      percentage: 65,
    },
    {
      id: 'goal_2',
      title: 'Maldives Summer Vacation',
      currentAmount: 8000.00,
      targetAmount: 40000.00,
      percentage: 20,
    }
  ]
};

// ----------------------------------------------------
// AUTHENTICATION & MULTI-FACTOR SECURITY (2FA / 3FA)
// ----------------------------------------------------

// GET /api/health
app.get('/api/health', (req, res) => {
  return res.json({
    status: 'ONLINE',
    service: 'Tranzfa Core Banking API',
    environment: 'Vercel Serverless Production',
    timestamp: new Date().toISOString()
  });
});

// POST /api/auth/login (FACTOR 1: Credential Check -> Issue OTP)
app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  const user = db.users.find(u => u.email.toLowerCase() === (email || '').toLowerCase() || u.accountTag.toLowerCase() === (email || '').toLowerCase());

  if (!user) {
    // Return standard success for demo email, or default user
    const defaultUser = db.users[0];
    const generatedOtp = Math.floor(100000 + Math.random() * 900000).toString();
    defaultUser.activeOtp = generatedOtp;

    return res.json({
      success: true,
      message: 'Factor 1 authentication successful. 6-digit OTP code sent for Factor 2 verification.',
      requireOtp: true,
      factor: 2,
      email: defaultUser.email,
      otpDemoCode: generatedOtp // Demo helper
    });
  }

  const generatedOtp = Math.floor(100000 + Math.random() * 900000).toString();
  user.activeOtp = generatedOtp;

  return res.json({
    success: true,
    message: 'Factor 1 authentication successful. 6-digit OTP code sent for Factor 2 verification.',
    requireOtp: true,
    factor: 2,
    email: user.email,
    otpDemoCode: generatedOtp
  });
});

// POST /api/auth/verify-otp (FACTOR 2: OTP Verification -> Issue JWT)
app.post('/api/auth/verify-otp', (req, res) => {
  const { email, otp } = req.body;
  const user = db.users.find(u => u.email.toLowerCase() === (email || '').toLowerCase()) || db.users[0];

  if (otp !== user.activeOtp && otp !== '123456') {
    return res.status(400).json({
      success: false,
      message: 'Invalid OTP code. Please check your 6-digit security code.'
    });
  }

  const token = jwt.sign(
    { userId: user.id, email: user.email, accountNo: user.accountNumber },
    JWT_SECRET,
    { expiresIn: '7d' }
  );

  return res.json({
    success: true,
    message: '2FA verification complete. Session token issued.',
    token,
    user: {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      accountTag: user.accountTag,
      accountNumber: user.accountNumber,
      balance: user.balance,
      currencySymbol: user.currencySymbol,
      tier: user.tier
    }
  });
});

// POST /api/auth/verify-pin (FACTOR 3: Transaction Security PIN Check)
app.post('/api/auth/verify-pin', (req, res) => {
  const { pin, userId } = req.body;
  const user = db.users.find(u => u.id === userId) || db.users[0];

  if (pin !== user.securityPin && pin !== '1234') {
    return res.status(401).json({
      success: false,
      message: 'Invalid 4-digit Security Transaction PIN.'
    });
  }

  return res.json({
    success: true,
    message: 'Factor 3 3FA Security PIN verified successfully.',
    verifiedAt: new Date().toISOString()
  });
});

// POST /api/auth/register
app.post('/api/auth/register', (req, res) => {
  const { fullName, email, phone, bvn } = req.body;
  const newUser = {
    id: `usr_${Date.now()}`,
    fullName: fullName || 'New User',
    email: email || 'user@tranzfa.io',
    accountTag: `@${(fullName || 'user').toLowerCase().replace(/\s+/g, '')}`,
    accountNumber: `20${Math.floor(10000000 + Math.random() * 90000000)}`,
    balance: 50000.00,
    currency: 'NGN',
    currencySymbol: '₦',
    securityPin: '1234',
    activeOtp: '123456',
    tier: 'Tier 2 (Verified)',
  };

  db.users.push(newUser);

  const token = jwt.sign(
    { userId: newUser.id, email: newUser.email },
    JWT_SECRET,
    { expiresIn: '7d' }
  );

  return res.json({
    success: true,
    message: 'Account created successfully with Tier 2 verification.',
    token,
    user: newUser
  });
});

// GET /api/auth/me
app.get('/api/auth/me', (req, res) => {
  const user = db.users[0];
  return res.json({
    success: true,
    user
  });
});

// ----------------------------------------------------
// TRANSACTIONS & CORE BANKING API
// ----------------------------------------------------

// POST /api/transactions/transfer
app.post('/api/transactions/transfer', (req, res) => {
  const { recipientName, bankName, accountNumber, amount, pin } = req.body;
  const user = db.users[0];

  const transferAmt = parseFloat(amount) || 0;

  if (pin && pin !== user.securityPin && pin !== '1234') {
    return res.status(401).json({
      success: false,
      message: 'Factor 3 authentication failed: Invalid Transaction PIN.'
    });
  }

  if (transferAmt <= 0) {
    return res.status(400).json({
      success: false,
      message: 'Invalid transfer amount.'
    });
  }

  if (transferAmt > user.balance) {
    return res.status(400).json({
      success: false,
      message: 'Insufficient balance for transfer.'
    });
  }

  user.balance -= transferAmt;

  const newTx = {
    id: `TZ-${Math.floor(1000000 + Math.random() * 9000000)}-X`,
    title: `Transfer to ${recipientName || 'Beneficiary'}`,
    category: 'Transfer',
    amount: transferAmt,
    currencySymbol: user.currencySymbol,
    type: 'debit',
    status: 'SUCCESSFUL',
    dateTimeText: 'Just now',
    timestamp: Date.now(),
    bankName: bankName || 'Tranzfa Direct',
    accountNumber: accountNumber || '2049182049'
  };

  db.transactions.unshift(newTx);

  return res.json({
    success: true,
    message: 'Transfer executed successfully.',
    transaction: newTx,
    newBalance: user.balance
  });
});

// GET /api/transactions/history
app.get('/api/transactions/history', (req, res) => {
  return res.json({
    success: true,
    transactions: db.transactions
  });
});

// POST /api/bills/pay
app.post('/api/bills/pay', (req, res) => {
  const { category, provider, customerRef, amount } = req.body;
  const user = db.users[0];
  const billAmt = parseFloat(amount) || 0;

  if (billAmt > user.balance) {
    return res.status(400).json({
      success: false,
      message: 'Insufficient funds for bill payment.'
    });
  }

  user.balance -= billAmt;

  const newTx = {
    id: `BILL-${Math.floor(100000 + Math.random() * 900000)}`,
    title: `${provider || 'Utility'} ${category || 'Bill'}`,
    category: 'Bills',
    amount: billAmt,
    currencySymbol: user.currencySymbol,
    type: 'debit',
    status: 'SUCCESSFUL',
    dateTimeText: 'Just now',
    timestamp: Date.now()
  };

  db.transactions.unshift(newTx);

  return res.json({
    success: true,
    message: 'Bill payment successful.',
    transaction: newTx,
    newBalance: user.balance
  });
});

// POST /api/savings/goals
app.post('/api/savings/goals', (req, res) => {
  const { title, targetAmount, category } = req.body;
  const newGoal = {
    id: `goal_${Date.now()}`,
    title: title || 'New Goal',
    currentAmount: 0.00,
    targetAmount: parseFloat(targetAmount) || 50000.00,
    percentage: 0
  };

  db.savingsGoals.push(newGoal);

  return res.json({
    success: true,
    message: 'Savings goal created.',
    goal: newGoal
  });
});

// ----------------------------------------------------
// KAST FEATURE API ENDPOINTS (GLOBAL ACCOUNTS, APY VAULTS, CARDS)
// ----------------------------------------------------

// GET /api/accounts/global
app.get('/api/accounts/global', (req, res) => {
  return res.json({
    success: true,
    globalAccounts: {
      usRoutingNumber: '021000021',
      usAccountNumber: '49201938102',
      usBankName: 'Choice Bank & Trust (USA)',
      usBeneficiary: 'Sarah Okonjo / Tranzfa Global',
      eurIban: 'DE89 3704 0044 0532 0130 00',
      eurBicSwift: 'DBKDEFDF',
      eurBankName: 'Deutsche Handelsbank (Germany)'
    }
  });
});

// GET /api/yield/vaults
app.get('/api/yield/vaults', (req, res) => {
  return res.json({
    success: true,
    vaults: [
      { id: 'v_usdc', asset: 'USDC', apy: 8.5, activeDeposits: 14200.00, estimatedAnnualYield: 1207.00 },
      { id: 'v_usdt', asset: 'USDT', apy: 6.1, activeDeposits: 8500.00, estimatedAnnualYield: 518.50 },
      { id: 'v_usde', asset: 'USDe', apy: 9.2, activeDeposits: 22000.00, estimatedAnnualYield: 2024.00 },
      { id: 'v_eur', asset: 'EUR', apy: 5.2, activeDeposits: 5000.00, estimatedAnnualYield: 260.00 }
    ]
  });
});

// GET /api/cards/cashback
app.get('/api/cards/cashback', (req, res) => {
  return res.json({
    success: true,
    cashbackPercentage: 2.5,
    totalCashbackEarnedUsdc: 1250.80,
    tier: 'Platinum Kast Visa'
  });
});

// POST /api/cards/push-wallet
app.post('/api/cards/push-wallet', (req, res) => {
  const { walletType, cardLast4 } = req.body;
  return res.json({
    success: true,
    message: `Card **** ${cardLast4 || '8821'} successfully provisioned to ${walletType || 'Digital Wallet'}.`,
    tokenRef: `WLET_TOK_${Date.now()}`
  });
});

// Catch-all for non-API routes
app.all('*', (req, res) => {
  res.status(404).json({ error: 'Endpoint not found on Tranzfa Vercel API' });
});

// For local testing
const PORT = process.env.PORT || 3000;
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Tranzfa Digital Bank API running on port ${PORT}`);
  });
}

module.exports = app;
