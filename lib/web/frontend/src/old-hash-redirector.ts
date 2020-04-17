type ReList = ReadonlyArray<readonly [RegExp, string]>;

const HASH_RES: ReList = [
  [/^\#\!\/(\d{4})\/(\d\d)\/(\d\d)\/(.*)$/, "/$1/$2/$3/$4"],
  [/^\#\!\/tag\/([^\/]+)$/, "/tag/$1"],
  [/^\#\!\/tag\/([^\/]+)(\/\d+)$/, "/tag/$1/p/$2"],
  [/^\#\!\/archives\/(\d{4})$/, "/archive/$1"],
  [/^\#\!\/archives\/(\d{4})\/(\d\d)$/, "/archive/$1/$2"],
  [/^\#\!\/archives\/(\d{4})(\/\d+)$/, "/archive/$1/p/$2"],
  [/\#\!\/archives\/(\d{4})\/(\d\d)(\/\d+)$/, "/archive/$1/$2/p/$3"],
  [/^\#\!\/(.*)$/, "/$1"],
] as const;

export function oldHashRedirector() {
  const currentHash = window.location.hash;

  for (const [re, path] of HASH_RES) {
    if (re.test(path)) {
      window.location.href = currentHash.replace(re, path);
      return;
    }
  }
}
