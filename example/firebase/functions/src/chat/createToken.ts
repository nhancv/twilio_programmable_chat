import * as functions from 'firebase-functions';
import { CallableContext } from 'firebase-functions/lib/providers/https';
import * as twilio from 'twilio';
/*
Title: Create token for Twilio Chat
Twilio Docs Access Tokens: https://www.twilio.com/docs/chat/create-tokens
*/

export const createToken = async (data: any, context: CallableContext) => {
    // If you plan to use Firebase Authentication, you could do some checks on the context.auth, like this:
    // if (!(context.auth && context.auth.token)) {
    //     throw new functions.https.HttpsError(
    //         'permission-denied',
    //         'Must be an authorized user to execute this function.'
    //     );
    // }

    if (!data.identity) {
        throw new functions.https.HttpsError('invalid-argument', 'identity is required!');
    }

    try {
        const AccessToken = twilio.jwt.AccessToken;

        // Create an access token which we will sign and return to the client,
        // containing the grant we just created
        const token = new AccessToken(
            process.env.TWILIO_ACCOUNT_SID as string,
            process.env.TWILIO_API_KEY as string,
            process.env.TWILIO_API_SECRET as string,
            {
                identity: data.identity
            }
        );

        // Grant the access token Twilio Chat capabilities
        token.addGrant(new AccessToken.ChatGrant({ serviceSid: process.env.TWILIO_SERVICE_SID }));

        console.log(`Identity ${data.identity} requested a token for chat`);

        // Serialize the token to a JWT string
        return {
            identity: data.identity,
            token: token.toJwt()
        };
    } catch (e) {
        console.error(e);
        throw new functions.https.HttpsError(
            'aborted',
            `${e}`
        );
    }
};
