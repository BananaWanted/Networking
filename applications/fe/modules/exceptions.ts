class Exception {
    tag?: string;
    extra?: any;

    constructor(tags?: any[] | string, extra?) {
        const tag_prefix = ['Exception', this.constructor.name]
        if (Array.isArray(tags)) {
            this.tag = [...tag_prefix, ...tags].join(".")
        } else if (tags) {
            this.tag = [...tag_prefix, tags].join(".");
        } else {
            this.tag = tag_prefix.join(".")
        }
        this.extra = extra;
    }
}

class FetchAPIException extends Exception {}
