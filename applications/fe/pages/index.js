// @flow

import React from 'react';
import Auth from '../modules/auth';
import Head from 'next/head'


export default class View extends React.Component {

    render() {
        // const auth = new Auth()
        // console.log(auth)
        // auth.login()

        console.log(this)

        return <>
        <Head>
            <title>the title</title>
        </Head>
        <h1>the h1</h1>
        </>
    }

}
