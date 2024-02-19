class ErrorNotifier extends BaseNotifier {
    static #NOTIFIER_ID = 'error-notifier';
    static #HIDDEN_CLASS_NAME = 'hidden-notifier';
    static #notifier = null;

    constructor(notifier_id) {
        super(notifier_id, ErrorNotifier.#HIDDEN_CLASS_NAME);
    }

    static get get() {
        if (ErrorNotifier.#notifier === null) {
            ErrorNotifier.#notifier = new ErrorNotifier(ErrorNotifier.#NOTIFIER_ID);
        }
        return ErrorNotifier.#notifier;
    }
}