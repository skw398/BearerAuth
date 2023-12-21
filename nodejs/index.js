const admin = require('firebase-admin');
const serviceAccount = require('admin.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
})

exports.handler = async (event, context, callback) => {
    const uid = await admin.auth().verifyIdToken(event.idToken)
        .then((decodedToken) => decodedToken.uid)
        .catch((error) => { return null; });

    return {
        message: uid == null ? '検証失敗' : '検証成功',
        uid: uid
    };
};