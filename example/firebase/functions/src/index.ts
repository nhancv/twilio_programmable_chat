import * as admin       from 'firebase-admin';
import * as functions   from 'firebase-functions';
import {RuntimeOptions} from 'firebase-functions/lib/function-configuration';
import * as chat       from './chat';

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

// Initialize our project application
admin.initializeApp(functions.config().firebase);

// Initialize environment variables
process.env.TWILIO_AUTH_TOKEN = functions.config().twilio.live.auth_token;
process.env.TWILIO_ACCOUNT_SID = functions.config().twilio.live.account_sid;
process.env.TWILIO_API_KEY = functions.config().twilio.api_key;
process.env.TWILIO_API_SECRET = functions.config().twilio.api_secret;
process.env.TWILIO_SERVICE_SID = functions.config().twilio.service_sid;

const region = functions.region('europe-west1');
const runtimeOptions: RuntimeOptions = {timeoutSeconds: 10, memory: '128MB'};

// Callable functions
export const createToken = region.runWith(runtimeOptions).https.onCall(chat.createToken);
