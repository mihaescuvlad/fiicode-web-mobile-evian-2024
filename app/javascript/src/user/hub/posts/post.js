class Post {
    #DomElementByClass = {
        obj: this,
        get element() {
            return this.obj.#domElement.querySelector(`.${this.className}`);
        }
    }

    #Toggleable = {
        __proto__: this.#DomElementByClass,

        shown: 'shown',
        hidden: 'hidden',

        set active(value) {
            if (![this.shown, this.hidden].includes(value))
                throw new Error("Invalid value for active");

            const [toAdd, toRemove] = (value === this.shown) ? [this.activeClasses, this.inactiveClasses] : [this.inactiveClasses, this.activeClasses];

            toRemove.forEach(cls => this.element.classList.remove(cls));
            toAdd.forEach(cls => this.element.classList.add(cls));
        },

        get active() {
            if (this.activeClasses.every(cls => this.element.classList.contains(cls)))
                return this.shown;
            if (this.inactiveClasses.every(cls => this.element.classList.contains(cls)))
                return this.hidden;

            throw new Error("Invalid state");
        }
    }

    #voteCounter = {
        __proto__: this.#DomElementByClass,
        className: 'counter'
    }

    #upvote = {
        __proto__: this.#Toggleable,

        id: "upvote",
        className: "uparrow",
        activeClasses: ["mdi-arrow-up-bold-circle", "text-primary-400"],
        inactiveClasses: ["mdi-arrow-up-bold-circle-outline"],
        weight: 1,
        valueOf: function () {
            return this.id;
        }
    }

    #downvote = {
        __proto__: this.#Toggleable,

        id: "downvote",
        className: "downarrow",
        activeClasses: ["mdi-arrow-down-bold-circle", "text-primary-400"],
        inactiveClasses: ["mdi-arrow-down-bold-circle-outline"],
        weight: -1,
        valueOf: function () {
            return this.id;
        }
    }

    #report = {
        __proto__: this.#Toggleable,

        className: "report-btn",
        activeClasses: ["mdi-flag", "text-primary-400"],
        inactiveClasses: ["mdi-flag-outline"],
    }

    #share = {
        __proto__: this.#Toggleable,
        className: "share-btn"
    }

    #domElement

    constructor(id) {
        this.#domElement = document.getElementById(id);

        [this.#downvote, this.#upvote].forEach((vote) => {
            vote.element.addEventListener("click", (e) => {
                e.stopPropagation();
                this.vote = this.vote !== vote ? vote : null;
            });
        });

        this.#share.element.addEventListener("click", (e) => {
            e.stopPropagation();
            const url = new URL(`https://${window.location.hostname}`)
            url.pathname = this.#share.element.getAttribute('href');
            navigator.clipboard.writeText(url.toString()).then(() => {
                SuccessNotifier.get.show("Link copied to clipboard", 1000);
            }).catch(() => {
                ErrorNotifier.get.show("Failed to copy link to clipboard", 2000);
            });
        });

        this.#report.element.addEventListener("click", (e) => {
            e.stopPropagation();
            this.report();
        });
    }

    get votesRatio() {
        return +this.#voteCounter.element.textContent;
    }

    set votesRatio(cnt) {
        this.#voteCounter.element.textContent = cnt;
    }

    get vote() {
        if (this.#upvote.active === this.#upvote.shown)
            return this.#upvote;
        if (this.#downvote.active === this.#downvote.shown)
            return this.#downvote;

        return null;
    }

    set vote(vote) {
        if (![this.#upvote, this.#downvote, null].includes(vote))
            throw new Error("Invalid vote type");

        const updateGUI = () => {
            const impact = (vote ? vote.weight : 0) - (this.vote ? this.vote.weight : 0);

            this.votesRatio += impact;

            [this.#upvote, this.#downvote].forEach((v) => {
                v.active = v.hidden;
            });

            if (!vote)
                return;

            vote.active = vote.shown;
        }

        if (vote === null) {
            $.ajax({
                url: `/hub/posts/${this.#domElement.id}/rating`,
                type: 'DELETE',
                complete: (_, status) => {
                    if (status !== "nocontent") {
                        ErrorNotifier.get.show("Failed to remove vote, please try again later");
                    } else {
                        updateGUI();
                    }
                }
            })
        } else {
            $.ajax({
                url: `/hub/posts/${this.#domElement.id}/rating`,
                type: 'POST',
                data: {vote: vote.id},
                complete: ({responseJSON: res}, status) => {
                    if (status !== "success") {
                        if (res && res.message)
                            ErrorNotifier.get.show(res.message);
                        else
                            ErrorNotifier.get.show("Failed to vote, please try again later");
                    } else {
                        updateGUI();
                    }
                }
            });
        }
    }

    report() {
        if (this.#report.active === this.#report.shown) {
            ErrorNotifier.get.show("You have already reported this post");
            return;
        }

        $.ajax({
            url: `/hub/posts/${this.#domElement.id}/report`,
            type: 'POST',
            complete: ({status}) => {
                if (status >= 200 && status < 300) {
                    this.#report.active = this.#report.shown;
                    SuccessNotifier.get.show("Post reported successfully");
                } else {
                    if (status == 401)
                        ErrorNotifier.get.show("You need to be logged in to report a post");
                    else
                        ErrorNotifier.get.show("Failed to report post, please try again later");
                }
            }
        });
    }
}

window.Post = Post;