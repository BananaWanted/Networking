export class DDNSRecord {
    user_id: number;
    public_id: string;
    secret_id: string;

    static async setup_new_ddns_record(user_id: number) {
        const setup_ddns_endpoint = new URL(`/api/ddns/setup/${user_id}`, window.location.href);
        const response = await fetch(setup_ddns_endpoint.href);
        if (response.ok) {
            const data = await response.json();
            new DDNSRecord(user_id, data.secret_id, data.public_id);
        }
        throw new FetchAPIException(['DDNS', 'SETUP'], response);
    }

    constructor(user_id: number, secret_id: string, public_id: string) {
        this.user_id = user_id;
        this.secret_id = secret_id;
    }
}
