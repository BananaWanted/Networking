import _ from 'lodash';
import auth0 from 'auth0-js';
import getConfig from 'next/config';
import URL from 'url-parse';
import Router from 'next/router';

const { publicRuntimeConfig } = getConfig();
const authProfileStorageKey = 'auth_profile';

type AuthResult = {
    accessToken: string,
    expiresIn: number,
    state: string,
    tokenType: 'Bearer',
    idToken: string,
    idTokenPayload: Object,
};

type AuthProfile = {
    accessToken: string,
    expiresAt: number,
    jwt: string,
};

export default class Auth {
    current_url: URL;
    auth0 = new auth0.WebAuth({
        domain: publicRuntimeConfig.AUTH0_DOMAIN,
        clientID: publicRuntimeConfig.AUTH0_CLIENT_ID,
    });

    constructor() {
        this.current_url = new URL(window.location.href, true);
        console.log('auth: current url:', this.current_url.toString());
    }

    routeToNext = () => {
        Router.replace(this.current_url.query.next);
    };

    login = () => {
        let redirectUri = new URL('/redirect', true);
        redirectUri.query.next = this.current_url.toString();

        this.auth0.authorize({
            redirectUri: redirectUri.toString(),
            audience: `https://${publicRuntimeConfig.AUTH0_DOMAIN}/userinfo`,
            responseType: 'token id_token',
            scope: 'openid',
        });
    };

    handleAuthentication = () => {
        this.auth0.parseHash((err, result: AuthResult) => {
            console.log('got auth result:', result);
            if (result && result.accessToken && result.idToken) {
                this.setSession(result);
                this.routeToNext();
            } else if (err) {
                this.routeToNext();
                console.log(err);
            }
        });
    };

    setSession = (result: AuthResult) => {
        let profile: AuthProfile = _.merge(result.idTokenPayload, {
            accessToken: result.accessToken,
            expiresAt: result.expiresIn * 1000 + new Date().getTime(),
            jwt: result.idToken,
        });
        console.log('got profile:', profile);
        let expiresAt = JSON.stringify();
        localStorage.setItem(authProfileStorageKey, JSON.stringify(profile));
    };

    logout = () => {
        localStorage.removeItem(authProfileStorageKey);
    };

    isAuthenticated = (): boolean => {
        let profile = Auth.retrieve();
        if (!profile) {
            return false;
        }
        return new Date().getTime() < profile.expiresAt;
    };

    static retrieve(): ?AuthProfile {
        if (typeof window === 'undefined') {
            return null;
        }
        let profile: AuthProfile = JSON.parse(localStorage.getItem(authProfileStorageKey) || 'false');
        if (!profile) {
            return null;
        }
        return profile;
    }
}
