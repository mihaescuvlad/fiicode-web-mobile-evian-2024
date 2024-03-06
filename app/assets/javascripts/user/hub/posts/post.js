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
    #domElement

    constructor(id) {
        this.#domElement = document.getElementById(id);

        [Post.downvote, Post.upvote].forEach((vote) => {
            this.#domElement.querySelector(`.${vote.className}`).addEventListener("click", (e) => {
                e.stopPropagation();
                this.vote = this.vote !== vote ? vote : null;
            });
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

        if (vote === null) {
            $.ajax({
                url: `/hub/posts/${this.#domElement.id}/rating`,
                type: 'DELETE',
            })

        } else {
            $.ajax({
                url: `/hub/posts/${this.#domElement.id}/rating`,
                type: 'POST',
                data: {vote: vote.id},
            });
        }

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
}
