export class Configuration {
    apiKey: string;
    username: string;
    password: string;
    otp_attempt: string;
    accessToken: string | (() => string);
}
