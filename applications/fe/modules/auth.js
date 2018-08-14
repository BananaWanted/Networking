// @flow

import auth0 from 'auth0-js';
import { AUTH0_DOMAIN, AUTH0_CLIENT_ID } from '../config';

export default class Auth {
    auth0 = new auth0.WebAuth({
        domain: AUTH0_DOMAIN,
        clientID: AUTH0_CLIENT_ID,
        redirectUri: '/callback',
        audience: AUTH0_DOMAIN + '/userinfo',
        responseType: 'token id_token',
        scope: 'openid'
    });

    login() {
        this.auth0.authorize();
    }
}
