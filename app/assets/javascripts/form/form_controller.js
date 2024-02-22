FormController = class {
    static #forms = {};

    #form;
    #middleware;

    /**
     * @param {string} formId The id of the form to control
     */
    constructor(formId) {
        FormController.#forms[formId] = this;

        this.#form = document.getElementById(formId);
        this.#middleware = [];

        this.#form.addEventListener('submit', async (event) => {
            event.preventDefault();

            const formData = new FormData(this.#form);
            const data = {};
            formData.forEach((value, key) => {
                data[key] = value;
            });

            this.disabled = true;
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
            this.disabled = false;
        });
    }

    /** @param {boolean} disable True if the form should be disabled, false if it should be enabled */
    set disabled(disable) {
        document.querySelectorAll(`#${this.#form.id} input, #${this.#form.id} button`).forEach((element) => {
            element.disabled = disable;
        })
    }

    static get(formId) {
        return FormController.#forms[formId];
    }

    async #runChain(res) {
        const contentType = res.headers.get('Content-Type').split(';')[0]
        const status = res.status
        const endpoint = (new URL(res.url)).pathname
        let data = await res.text();

        const chain = [this.#parseJson, ...this.#middleware, this.#notifyJson, this.#renderHtml()];
        for (const middleware of chain) {
            data = middleware(data, {contentType, status, endpoint});
            if (data instanceof Promise)
                data = await data;

            if (data === null)
                return;
        }
    }

    /**
     * @param {(data: T, {status: number, contentType: string, endpoint: string}) => T | null} middleware
     *      Function that takes the response data and modifies it
     *      before passing it on to the chain, or returns null stopping it
     */
    appendMiddleware(middleware) {
        this.#middleware.push(middleware);
        return this;
    }

    /******************************
     HERE BEGIN DEFAULT MIDDLEWARES
     ******************************/

    #parseJson(data, {contentType}) {
        if (contentType === 'application/json')
            return JSON.parse(data);
        return data;
    }

    /**
     *  If the response is a json object and has a message property, it will
     *  be shown as a success or error notification, depending on the http status.
     */
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

    /**
     *  Runs if the response is of type text/html.
     *
     *  If the htmlfor attribute is set, the response will be rendered into the
     *  element specified by the query selector.
     *
     *  Otherwise the whole page will be replaced with the new content,
     *  and the url will be properly updated.
     *
     *  @warning: In the latter case, variables from the old page will persist.
     *            To avoid redeclaration errors, it is recommended to use
     *            all globals on the window object.
     */
    #renderHtml() {
        const form = this.#form
        return (data, {contentType, endpoint}) => {
            if (contentType !== 'text/html')
                return data

            const qSelector = form.getAttribute("htmlfor")
            if (!qSelector) {
                document.open()
                history.replaceState({}, '', endpoint)
                document.write(data)
                document.close()

                return null
            }

            const container = document.querySelector(qSelector)
            container.innerHTML = data
            return data
        }
    }
}