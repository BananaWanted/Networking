// @flow

import React from 'react';
import Auth from '../modules/auth';

export default class Next extends React.Component<{}> {
    render() {
        return <p>redirecting...</p>;
    }

    componentDidMount() {
        let auth = new Auth();
        auth.handleAuthentication();
    }
}
