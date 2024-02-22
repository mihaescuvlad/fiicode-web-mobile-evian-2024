SuccessNotifier = class extends BaseNotifier {
    static #NOTIFIER_ID = 'success-notifier';
    static #HIDDEN_CLASS_NAME = 'hidden-notifier';
    static #notifier = null;

    constructor(notifier_id) {
        super(notifier_id, SuccessNotifier.#HIDDEN_CLASS_NAME);
    }

    static get get() {
        if (SuccessNotifier.#notifier === null) {
            SuccessNotifier.#notifier = new SuccessNotifier(SuccessNotifier.#NOTIFIER_ID);
        }
        return SuccessNotifier.#notifier;
    }
}