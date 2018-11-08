const { FuseBox, QuantumPlugin, SassPlugin, CSSPlugin, CSSResourcePlugin } = require("fuse-box");

const DIST_PATH = '../../../priv/static';

const BUILD_ONLY = process.argv.length > 2 && process.argv[2] === 'build';

const IS_PRODUCTION = process.env.NODE_ENV === 'production';

const fuse = FuseBox.init({
  homeDir: 'src',
  output: `${DIST_PATH}/$name.js`,
  target: 'browser@es5',
  sourceMaps: true,
  plugins: [
    [
      SassPlugin(),
      CSSResourcePlugin({ dist: `${DIST_PATH}/css-resources` }),
      CSSPlugin(),
    ],
    IS_PRODUCTION && QuantumPlugin({
      bakeApiIntoBundle: 'app',
      uglify: true,
      css: true,
    })
  ]
});

if (!IS_PRODUCTION && !BUILD_ONLY) {
  fuse.dev({
    port: 2125,
    proxy: {
      '/': {
        target: 'http://127.0.0.1:2124',
        changeOrigin: true
      }
    }
  });
}

const app = fuse.bundle('app').instructions(`> index.bs.js + style/index.scss`);

if (!IS_PRODUCTION && !BUILD_ONLY) {
  app.hmr({ reload: true }).watch();
}

fuse.run();
