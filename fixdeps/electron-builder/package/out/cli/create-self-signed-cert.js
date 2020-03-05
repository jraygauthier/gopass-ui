"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.createSelfSignedCert = createSelfSignedCert;

function _bluebirdLst() {
  const data = require("bluebird-lst");

  _bluebirdLst = function () {
    return data;
  };

  return data;
}

function _builderUtil() {
  const data = require("builder-util");

  _builderUtil = function () {
    return data;
  };

  return data;
}

function _fs() {
  const data = require("builder-util/out/fs");

  _fs = function () {
    return data;
  };

  return data;
}

function _chalk() {
  const data = _interopRequireDefault(require("chalk"));

  _chalk = function () {
    return data;
  };

  return data;
}

function _windowsCodeSign() {
  const data = require("app-builder-lib/out/codeSign/windowsCodeSign");

  _windowsCodeSign = function () {
    return data;
  };

  return data;
}

function _fsExtraP() {
  const data = require("fs-extra-p");

  _fsExtraP = function () {
    return data;
  };

  return data;
}

var path = _interopRequireWildcard(require("path"));

function _sanitizeFilename() {
  const data = _interopRequireDefault(require("sanitize-filename"));

  _sanitizeFilename = function () {
    return data;
  };

  return data;
}

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) { var desc = Object.defineProperty && Object.getOwnPropertyDescriptor ? Object.getOwnPropertyDescriptor(obj, key) : {}; if (desc.get || desc.set) { Object.defineProperty(newObj, key, desc); } else { newObj[key] = obj[key]; } } } } newObj.default = obj; return newObj; } }

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

/** @internal */
function createSelfSignedCert(_x) {
  return _createSelfSignedCert.apply(this, arguments);
}

function _createSelfSignedCert() {
  _createSelfSignedCert = (0, _bluebirdLst().coroutine)(function* (publisher) {
    const tmpDir = new (_builderUtil().TmpDir)("create-self-signed-cert");
    const targetDir = process.cwd();
    const tempPrefix = path.join((yield tmpDir.getTempDir({
      prefix: "self-signed-cert-creator"
    })), (0, _sanitizeFilename().default)(publisher));
    const cer = `${tempPrefix}.cer`;
    const pvk = `${tempPrefix}.pvk`;

    _builderUtil().log.info(_chalk().default.bold('When asked to enter a password ("Create Private Key Password"), please select "None".'));

    try {
      yield (0, _fsExtraP().ensureDir)(path.dirname(tempPrefix));
      const vendorPath = path.join((yield (0, _windowsCodeSign().getSignVendorPath)()), "windows-10", process.arch);
      yield (0, _builderUtil().exec)(path.join(vendorPath, "makecert.exe"), ["-r", "-h", "0", "-n", `CN=${quoteString(publisher)}`, "-eku", "1.3.6.1.5.5.7.3.3", "-pe", "-sv", pvk, cer]);
      const pfx = path.join(targetDir, `${(0, _sanitizeFilename().default)(publisher)}.pfx`);
      yield (0, _fs().unlinkIfExists)(pfx);
      yield (0, _builderUtil().exec)(path.join(vendorPath, "pvk2pfx.exe"), ["-pvk", pvk, "-spc", cer, "-pfx", pfx]);

      _builderUtil().log.info({
        file: pfx
      }, `created. Please see https://electron.build/code-signing how to use it to sign.`);

      const certLocation = "Cert:\\LocalMachine\\TrustedPeople";

      _builderUtil().log.info({
        file: pfx,
        certLocation
      }, `importing. Operation will be succeed only if runned from root. Otherwise import file manually.`);

      yield (0, _builderUtil().spawn)("powershell.exe", ["-NoProfile", "-NonInteractive", "-Command", "Import-PfxCertificate", "-FilePath", `"${pfx}"`, "-CertStoreLocation", ""]);
    } finally {
      yield tmpDir.cleanup();
    }
  });
  return _createSelfSignedCert.apply(this, arguments);
}

function quoteString(s) {
  if (!s.includes(",") && !s.includes('"')) {
    return s;
  }

  return `"${s.replace(/"/g, '\\"')}"`;
} 
// __ts-babel@6.0.4
//# sourceMappingURL=create-self-signed-cert.js.map