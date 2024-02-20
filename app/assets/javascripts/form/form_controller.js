class FormController {
    #form;
    #middleware;

    /**
     * @param {string} formId The id of the form to control
     */
    constructor(formId) {
        this.#form = document.getElementById(formId);
        this.#middleware = [];

        this.#form.addEventListener('submit', async (event) => {
            event.preventDefault();

            const formData = new FormData(this.#form);
            const data = {};
            formData.forEach((value, key) => {
                data[key] = value;
            });

            let endpoint = this.#form.action;
            const isGet = this.#form.method.toUpperCase() === 'GET';
            if (isGet) {
                endpoint += '?' + new URLSearchParams(data).toString();
            }
            const body = isGet ? {} : {body: JSON.stringify(data)};

            const res = await fetch(endpoint, {
                method: this.#form.method,
                ...body
            });

            await this.#runChain(res);
        });
    }

    async #runChain(res) {
        let [contentType, status, data] = [res.headers.get('Content-Type').split(';')[0], res.status, await res.text()];

        const chain = [this.#parseJson, ...this.#middleware, this.#notifyJson];
        for (const middleware of chain) {
            data = middleware(data, {contentType, status});
            if (data instanceof Promise)
                data = await data;

            if (data === null)
                return;
        }
    }

    /**
     * @param {(data: T, {status: number, contentType: string}) => T | null} middleware
     *      Function that takes the response data and modifies it
     *      before passing it on to the chain, or returns null stopping it
     */
    appendMiddleware(middleware) {
        this.#middleware.push(middleware);
        return this;
    }

    #parseJson(data, {contentType}) {
        if (contentType === 'application/json')
            return JSON.parse(data);
        return data;
    }

    #notifyJson(data, {contentType, status}) {
        if (status >= 500) {
            ErrorNotifier.get.show('Something went wrong.');
            return data
        }

        if (contentType !== 'application/json' || !data.message)
            return data

        if (status >= 200 && status < 300)
            SuccessNotifier.get.show(data.message);
        else
            ErrorNotifier.get.show(data.message);

        return data
    }
}