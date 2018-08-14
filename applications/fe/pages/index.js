import React from 'react';
import Auth from '../modules/auth';
import Head from 'next/head';
import Link from 'next/link';
import Router from 'next/router'


export default class View extends React.Component {

    render() {
        return <>
        <Head>
            <title>the title</title>
        </Head>
        <h1>the h1</h1>
        <p>
            <Link prefetch href="/ddns">
                <a>goto p2</a>
            </Link>
        </p>

        <div onClick={ () => Router.push("/ddns", "/xxx") } >some thing</div>
        </>
    }

    componentDidMount() {
        // const auth = new Auth()
        // auth.login()
    }

}
