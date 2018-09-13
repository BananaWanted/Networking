module.exports = {
    generateBuildId: () => process.env.BUILD_TAG,
    serverRuntimeConfig: {
    },
    publicRuntimeConfig: {
        AUTH0_DOMAIN: process.env.AUTH0_DOMAIN,
        AUTH0_CLIENT_ID: process.env.AUTH0_CLIENT_ID,
    },
}
