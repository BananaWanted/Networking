import Auth from 'modules/auth';
import Head from 'next/head';
import Link from 'next/link';
import React from 'react';
import Router from 'next/router';
import URL from 'url-parse';
import getConfig from 'next/config';

const { publicRuntimeConfig } = getConfig();

export default class DDNSPage extends React.Component<{}> {
    ddns_setup_url: string
    ddns_reporting_url: string
}
