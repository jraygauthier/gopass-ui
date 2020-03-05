
```
  "scripts": {
    "build-main": "cross-env NODE_ENV=production webpack --config webpack.main.prod.config.js",
    "build-renderer-search": "cross-env NODE_ENV=production webpack --config webpack.renderer.search.prod.config.js",
    "build-renderer-explorer": "cross-env NODE_ENV=production webpack --config webpack.renderer.explorer.prod.config.js",
    "build": "npm run build-main && npm run build-renderer-explorer && npm run build-renderer-search",
    "start-renderer-search-dev": "NODE_OPTIONS=\"--max-old-space-size=2048\" webpack-dev-server --config webpack.renderer.search.dev.config.js",
    "start-renderer-explorer-dev": "NODE_OPTIONS=\"--max-old-space-size=2048\" webpack-dev-server --config webpack.renderer.explorer.dev.config.js",
    "start-main-dev": "webpack --config webpack.main.config.js && electron ./dist/main.js",
    "prestart": "npm run build",
    "start": "electron .",
    "prettier:check": "prettier --check {src,test,mocks}/**/*.{ts,tsx,js,jsx}",
    "prettier:write": "prettier --write {src,test,mocks}/**/*.{ts,tsx,js,jsx}",
    "lint": "tslint '{src,test,mocks}/**/*.{ts,tsx,js,jsx}' --project ./tsconfig.json",
    "lint:fix": "tslint '{src,test,mocks}/**/*.{ts,tsx}' --project ./tsconfig.json --fix",
    "test": "npm run test:unit",
    "test:unit": "jest --testRegex '\\.test\\.tsx?$'",
    "test:unit:watch": "jest --testRegex '\\.test\\.tsx?$' --watch",
    "test:integration": "jest --testRegex '\\.itest\\.ts$'",
    "release:check": "npm run lint && npm test",
    "release": "npm run release:check && npm run build && electron-builder --publish onTag",
    "postinstall": "electron-builder install-app-deps"
  },
```