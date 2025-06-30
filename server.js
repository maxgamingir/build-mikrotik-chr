const { Client } = require("ssh2");
const fs = require("fs/promises");
const path = require("path");
const { Readable } = require("stream");
const conn = new Client();
require("dotenv").config();

if (
	!process.env.HOST ||
	!process.env.MIKROTIK_PASSWORD ||
	!process.env.USERNAME ||
	!process.env.PASSWORD ||
	!process.env.MIKROTIK_ACCOUNT ||
	!process.env.MIKROTIK_ACCOUNT_PASSWORD
) {
	throw new Error("❌ Missing one or more required .env values.");
}

const env = {
	host: {
		host: process.env.HOST,
		port: parseInt(process.env.PORT ?? "22", 10),
		username: process.env.USERNAME,
		password: process.env.PASSWORD,
	},
	config: {
		mikVersion: process.env.MIKROTIK_VERSION ?? "7.8",
		password: process.env.MIKROTIK_PASSWORD,
		extraConfigs: process.env.MIKROTIK_EXTRA_CONFIGS ?? "",
		dns: process.env.MIKROTIK_DNS ?? "8.8.8.8",
	},
	Mikrotiklicence: {
		account: process.env.MIKROTIK_ACCOUNT,
		password: process.env.MIKROTIK_ACCOUNT_PASSWORD,
	},
};

const sshConfig = {
	host: env.host.host,
	port: env.host.port,
	username: env.host.username,
	password: env.host.password,
};

const localScriptPath = path.join(__dirname, "build.sh");
const remoteScriptPath = "/tmp/build.sh";

async function createReplacedStream() {
	let content = await fs.readFile(localScriptPath, "utf8");
	content = content
		.replace(/{mikVersion}/g, env.config.mikVersion)
		.replace(/{password}/g, env.config.password)
		.replace(/{dns}/g, env.config.dns)
		.replace(/{licence-account}/g, env.Mikrotiklicence.account)
		.replace(/{licence-password}/g, env.Mikrotiklicence.password)
		.replace(/{extraConfigs}/g, env.config.extraConfigs);

	return Readable.from([content]);
}

conn
	.on("ready", async () => {
		console.log("OK: SSH connection ready.");

		conn.sftp(async (err, sftp) => {
			if (err) throw err;

			const replacedStream = await createReplacedStream();
			const writeStream = sftp.createWriteStream(remoteScriptPath);

			writeStream.on("close", () => {
				console.log("OK: script uploaded to server.");
				conn.exec(
					`chmod +x ${remoteScriptPath} && ${remoteScriptPath}`,
					(err, stream) => {
						if (err) throw err;

						stream
							.on("close", (code, signal) => {
								console.log(`script finished. Result: ${code}`);
								conn.end();
							})
							.on("data", (data) => {
								process.stdout.write(`\x1b[32m[stdout]\x1b[0m ${data}`);
							})
							.stderr.on("data", (data) => {
								process.stderr.write(`\x1b[31m[stderr]\x1b[0m ${data}`);
							});
					}
				);
			});

			replacedStream.pipe(writeStream);
		});
	})
	.on("error", (err) => {
		console.error("xxxxxxERRxxxxxx: SSH Connection error:", err.message);
	})
	.connect(sshConfig);
