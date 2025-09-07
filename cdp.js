// connect to the Chrome DevTools Protocol
const CDP = require('chrome-remote-interface');

const port = 9234; // default port for Chrome DevTools Protocol
const host = '127.0.0.1';

async function connectToCDP() {
    try {

        console.log(`Connecting to Chrome DevTools Protocol on port ${host}${port}...`);
        const client = await CDP({ host, port });
        console.log('Connected to Chrome DevTools Protocol');

        const { Network, Page } = client;

        await Network.enable();
        await Page.enable();

        Page.loadEventFired(() => {
            console.log('Page loaded');
        });

        await Page.navigate({ url: 'https://wikipedia.org' });

        Page.on('frameNavigated', (params) => {
            console.log('Frame navigated to: ' + params.frame.url);
        });

    } catch (err) {
        console.error('Error connecting to CDP:', err);
    }
}

connectToCDP();