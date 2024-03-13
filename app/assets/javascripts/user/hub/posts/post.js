class Post {
    static upvote = {
        id: "upvote",
        className: "uparrow",
        activeClass: "mdi-arrow-up-bold-circle",
        inactiveClass: "mdi-arrow-up-bold-circle-outline",
        weight: 1,
        valueOf: function () {
            return this.id;
        }
    }

    static downvote = {
        id: "downvote",
        className: "downarrow",
        activeClass: "mdi-arrow-down-bold-circle",
        inactiveClass: "mdi-arrow-down-bold-circle-outline",
        weight: -1,
        valueOf: function () {
            return this.id;
        }
    }

    static report = {
        className: "report-btn",
        activeClass: "mdi-flag",
        inactiveClass: "mdi-flag-outline",
    }

    static shareClassName = "share-btn";

    #domElement

    constructor(id) {
        this.#domElement = document.getElementById(id);

        [Post.downvote, Post.upvote].forEach((vote) => {
            this.#domElement.querySelector(`.${vote.className}`).addEventListener("click", (e) => {
                e.stopPropagation();
                this.vote = this.vote !== vote ? vote : null;
            });
        });

        const shareButton = this.#domElement.querySelector(`.${Post.shareClassName}`);
        shareButton.addEventListener("click", (e) => {
            e.stopPropagation();
            const url = new URL(`https://${window.location.hostname}`)
            url.pathname = shareButton.getAttribute('href');
            navigator.clipboard.writeText(url.toString()).then(() => {
                SuccessNotifier.get.show("Link copied to clipboard", 1000);
            }).catch(() => {
                ErrorNotifier.get.show("Failed to copy link to clipboard", 2000);
            });
        });

        this.#domElement.querySelector(`.${Post.report.className}`).addEventListener("click", (e) => {
            e.stopPropagation();
            this.report();
        });
    }

    get votesRatio() {
        return +this.#domElement.querySelector(".counter").textContent;
    }

    set votesRatio(cnt) {
        this.#domElement.querySelector(".counter").textContent = cnt;
    }

    get vote() {
        if (this.#domElement.querySelector(`.${Post.upvote.className}`).classList.contains(Post.upvote.activeClass))
            return Post.upvote;
        if (this.#domElement.querySelector(`.${Post.downvote.className}`).classList.contains(Post.downvote.activeClass))
            return Post.downvote;

        return null;
    }

    set vote(vote) {
        if (![Post.upvote, Post.downvote, null].includes(vote))
            throw new Error("Invalid vote type");

        const updateGUI = () => {
            const impact = (vote ? vote.weight : 0) - (this.vote ? this.vote.weight : 0);

            this.votesRatio += impact;

            [Post.upvote, Post.downvote].forEach((v) => {
                this.#domElement.querySelector(`.${v.className}`).classList.remove(v.activeClass);
                this.#domElement.querySelector(`.${v.className}`).classList.add(v.inactiveClass);
            });

            if (!vote)
                return;

            this.#domElement.querySelector(`.${vote.className}`).classList.remove(vote.inactiveClass);
            this.#domElement.querySelector(`.${vote.className}`).classList.add(vote.activeClass);
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
        const reportButton = this.#domElement.querySelector(`.${Post.report.className}`);
        if (reportButton.classList.contains(Post.report.activeClass)) {
            ErrorNotifier.get.show("You have already reported this post");
            return;
        }

        $.ajax({
            url: `/hub/posts/${this.#domElement.id}/report`,
            type: 'POST',
            complete: ({status}) => {
                if (status >= 200 && status < 300) {
                    reportButton.classList.remove(Post.report.inactiveClass);
                    reportButton.classList.add(Post.report.activeClass);
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
