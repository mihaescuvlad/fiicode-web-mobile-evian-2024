FormController = class {
    static #forms = {};

    #form;
    #disabled_inputs;
    #middleware;

    /**
     * @param {string} formId The id of the form to control
     */
    constructor(formId) {
        FormController.#forms[formId] = this;

        this.#form = document.getElementById(formId);
        this.#middleware = [];
        this.#disabled_inputs = Array.from(document.querySelectorAll(`#${this.#form.id} input`)).filter(input => input.disabled);

        this.#form.addEventListener('submit', async (event) => {
            event.preventDefault();

            const formData = new FormData(this.#form);
            const data = this.#convertFormDataToObject(formData);

            this.disabled = true;

            let endpoint = this.#form.action;
            const isGet = this.#form.getAttribute("method").toUpperCase() === 'GET';
            if (isGet) {
                endpoint += '?' + new URLSearchParams(data).toString();
            }

            const body = isGet ? {} : {body: JSON.stringify(data)};

            const res = await fetch(endpoint, {
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': formData["authenticity_token"]
                },
                method: this.#form.getAttribute("method"),
                ...body
            });

            await this.#runChain(res);
            this.disabled = false;
        });
    }

    /** @param {boolean} disable True if the form should be disabled, false if it should be enabled */
    set disabled(disable) {
        Array.from(document.querySelectorAll(`#${this.#form.id} input, #${this.#form.id} button`))
            .filter(input => this.#disabled_inputs.indexOf(input) < 0)
            .forEach((element) => {
                element.disabled = disable;
            })
    }

    static get(formId) {
        return FormController.#forms[formId];
    }

    async #runChain(res) {
        const headers = res.headers;
        const contentType = res.headers.get('Content-Type').split(';')[0]
        const status = res.status
        const endpoint = (new URL(res.url)).pathname
        let data = await res.text();

        const chain = [this.#parseJson, ...this.#middleware, this.#renderHtml(), this.#notifyJson];
        for (const middleware of chain) {
            data = middleware(data, {contentType, status, endpoint, headers});
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


    /**
     * @param {FormData} formData
     */
    #convertFormDataToObject(formData) {
        const object = {};
        formData.forEach((value, key) => {
            if (!object[key] && key.endsWith("[]"))
                object[key] = []

            if (!object[key])
                object[key] = value;
            else if (Array.isArray(object[key]))
                object[key].push(value);
            else
                object[key] = [object[key], value];
        });
        return object;
    }

    #seconds(s) {
        return new Promise((res) => {
            setTimeout(() => res(null), s * 1000)
        })
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
    async #notifyJson(data, {contentType, status, headers}) {
        if (status >= 500) {
            ErrorNotifier.get.show('Something went wrong.');
            return data
        }

        let msg = ""
        if (contentType === 'application/json') {
            msg = data.message ?? ""
        } else if (contentType === 'text/html') {
            msg = headers.get('Alert-Message') ?? ""
        }

        if (!msg)
            return data

        while (true) {
            let notifier;
            if (status >= 200 && status < 300)
                notifier = SuccessNotifier.get;
            else
                notifier = ErrorNotifier.get;

            if (notifier) {
                notifier.show(msg);
                return data
            }

            await this.#seconds(0.5)
        }
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
        return (data, {contentType, endpoint, status}) => {
            if (contentType !== 'text/html' || status >= 500)
                return data

            const qSelector = form.getAttribute("htmlfor")
            if (qSelector) {
                const container = document.querySelector(qSelector)
                container.innerHTML = data

                return data
            }

            document.open()
            history.replaceState({}, '', endpoint)
            document.write(data)
            document.close()
            return data
        }
    }
}