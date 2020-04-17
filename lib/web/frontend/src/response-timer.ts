import { LOCALE } from "./config.js";

const TIME_UNITS: Array<[number, string]> = [
  [10 ** 6, "s"],
  [10 ** 3, "ms"],
];

function getCookieValue(name: string): string {
  const b = document.cookie.match(`(^|;)\\s*${name}\\s*=\\s*([^;]+)`);
  return b && b.length > 0 ? b.pop() as string : "";
}

function formatTime(time: number): string {
  let formatUnit = "µs";
  for (const [limit, unit] of TIME_UNITS) {
    if (time >= limit) {
      time = time / limit;
      formatUnit = unit;
    }
  }

  const formatter = new Intl.NumberFormat(
    LOCALE,
    {
      style: "decimal",
      maximumFractionDigits: 2,
    },
  );

  return `${formatter.format(time)} ${formatUnit}`;
}

function getFormattedTime(cookieName: string): string {
  const time = parseInt(getCookieValue(cookieName), 10);

  if (!isNaN(time)) {
    return ` · ${formatTime(time)}`;
  } else {
    return "";
  }
}

export function renderTimeText() {
  const tag = document.getElementById("request-timer");

  if (tag === null) {
    throw new Error("Request timer DOM element missing!");
  }

  tag.innerText = getFormattedTime("mebe2-request-timer");
}
