import Auth from '../modules/auth';
import React from 'react';

export default class Next extends React.Component<{}> {
    render() {
        return <p>redirecting...</p>;
    }

    componentDidMount() {
        let auth = new Auth();
        auth.handleAuthentication();
    }
}
