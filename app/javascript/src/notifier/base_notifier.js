export default window.BaseNotifier = class {
    static #activeNotifier = null;

    #dom_object;
    #closeTimeout;
    #shown;
    #hiddenClassName;

    constructor(notifierId, hiddenClassName) {
        this.#dom_object = document.getElementById(notifierId);
        this.#closeTimeout = null;
        this.#hiddenClassName = hiddenClassName;
        this.#shown = false

        this.#dom_object.addEventListener('click', () => {
            this.shown = false;
        });
    }

    /** @returns {boolean} True if the notification is hidden, false if it is displayed */
    get shown() {
        return this.#shown;
    }

    /**
     * Sets whether the notification is displayed
     * @param {boolean} show False if the notification should be hidden, true if it should be displayed
     * @note: This will clear any timeout set to close the notification
     * @note: If the property is set to the same value as it already is, nothing happens
     */
    set shown(show) {
        if (this.#closeTimeout !== null) {
            clearTimeout(this.#closeTimeout);
            this.#closeTimeout = null;
        }

        if (this.shown === show)
            return;
        this.#shown = show;

        if (!show) {
            this.#dom_object.classList.add(this.#hiddenClassName);

            console.assert(BaseNotifier.#activeNotifier === this, 'Notifier is not active notifier')
            BaseNotifier.#activeNotifier = null;
        } else {
            this.#dom_object.classList.remove(this.#hiddenClassName);

            if (BaseNotifier.#activeNotifier !== null) {
                BaseNotifier.#activeNotifier.shown = false;
            }
            BaseNotifier.#activeNotifier = this;
        }
    }

    /** @param {string} text Text to display in the notification */
    set text(text) {
        const p_tag = document.querySelector(`#${this.#dom_object.id} p`);
        p_tag.innerText = text;
    }

    get valid() {
        return this.#dom_object !== null;
    }

    /**
     * Displays notification for a given time
     * @param {string} text Text to display in the notification
     * @param {number} timeout Time in milliseconds to display the notification
     */
    show(text, timeout = 7000) {
        this.text = text;
        this.shown = true;
        this.#closeTimeout = setTimeout(() => {
            this.shown = false;
        }, timeout);
        return this
    }

}