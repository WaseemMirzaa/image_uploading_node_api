const axios = require('axios');

const BASE_URL = 'http://localhost:3001';

async function testEmailService() {
  console.log('🧪 Testing 4 Secrets Wedding Email Service...\n');

  try {
    // Test 1: Health Check
    console.log('1. Testing Health Check...');
    const healthResponse = await axios.get(`${BASE_URL}/health`);
    console.log('✅ Health Check:', healthResponse.data);
    console.log('');

    // Test 2: Email Status
    console.log('2. Testing Email Status...');
    const statusResponse = await axios.get(`${BASE_URL}/api/email/status`);
    console.log('✅ Email Status:', statusResponse.data);
    console.log('');

    // Test 3: Send Invitation Email
    console.log('3. Testing Send Invitation Email...');
    const invitationResponse = await axios.post(`${BASE_URL}/api/email/send-invitation`, {
      email: 'test@example.com',
      inviterName: 'Test User'
    });
    console.log('✅ Invitation Email:', invitationResponse.data);
    console.log('');

    // Test 4: Send Declined Email
    console.log('4. Testing Send Declined Email...');
    const declinedResponse = await axios.post(`${BASE_URL}/api/email/declined-invitation`, {
      email: 'test@example.com',
      declinerName: 'Test Decliner'
    });
    console.log('✅ Declined Email:', declinedResponse.data);
    console.log('');

    // Test 5: Send Revoked Access Email
    console.log('5. Testing Send Revoked Access Email...');
    const revokedResponse = await axios.post(`${BASE_URL}/api/email/revoke-access`, {
      email: 'test@example.com',
      inviterName: 'Test Admin'
    });
    console.log('✅ Revoked Access Email:', revokedResponse.data);
    console.log('');

    // Test 6: Send Custom Email
    console.log('6. Testing Send Custom Email...');
    const customResponse = await axios.post(`${BASE_URL}/api/email/send-custom`, {
      email: 'test@example.com',
      subject: 'Test Custom Email',
      message: 'This is a test custom email from the cloud function.'
    });
    console.log('✅ Custom Email:', customResponse.data);
    console.log('');

    // Test 7: Send Welcome Email
    console.log('7. Testing Send Welcome Email...');
    const welcomeResponse = await axios.post(`${BASE_URL}/api/email/send-welcome`, {
      email: 'test@example.com',
      userName: 'Test User'
    });
    console.log('✅ Welcome Email:', welcomeResponse.data);
    console.log('');

    // Test 8: Get Sent Emails
    console.log('8. Testing Get Sent Emails...');
    const sentEmailsResponse = await axios.get(`${BASE_URL}/api/email/sent`);
    console.log('✅ Sent Emails Count:', sentEmailsResponse.data.count);
    console.log('');

    console.log('🎉 All tests completed successfully!');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

// Run tests if this file is executed directly
if (require.main === module) {
  testEmailService();
}

module.exports = testEmailService;
