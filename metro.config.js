// Polyfill for Array.prototype.toReversed if it doesn't exist
if (!Array.prototype.toReversed) {
  Array.prototype.toReversed = function() {
    return this.slice().reverse();
  };
}

// Learn more https://docs.expo.io/guides/customizing-metro
const { getDefaultConfig } = require('expo/metro-config');
const path = require('path');

const config = getDefaultConfig(__dirname);

config.resolver.resolveRequest = (context, moduleName, platform) => {
  if (platform === 'web' && moduleName.includes('PermissionsAndroid')) {
    return {
      filePath: path.resolve(__dirname, 'mocks/PermissionsAndroid.js'),
      type: 'sourceFile',
    };
  }
  return context.resolveRequest(context, moduleName, platform);
};

module.exports = config;