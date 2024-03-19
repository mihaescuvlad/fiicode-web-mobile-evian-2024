import React, {useState} from "react";

const UserCard = (props) => {
    const [following, setFollowing] = useState(props.following);
    const [loading, setLoading] = useState(false);

    const toggleFollow = async (e) => {
        e.stopPropagation();
        setLoading(true);
        try {
            await fetch(props.follow_path, {
                method: "HEAD",
            });
        } catch {
            ErrorNotifier.get.show("Something went wrong.");
        }

        setLoading(false);
        setFollowing(!following);
    };

    return (
        <div
            onClick={() => (location.href = props.user_path)}
            className="bg-white rounded-lg shadow-md w-full p-4 flex justify-between items-center gap-1 cursor-pointer"
        >
            <div className="flex gap-1 items-center">
                <img src={props.profile_picture_url} className="w-10 h-10 rounded-full" alt="avatar"/>
                <h2 className="text-lg truncate">{props.username}</h2>
            </div>
            {following !== null &&
                (!loading ? (
                    following ? (
                        <button
                            onClick={toggleFollow}
                            className="follow-btn bg-slate-600 rounded-lg w-32 text-white py-1"
                        >
                            Unfollow
                        </button>
                    ) : (
                        <button
                            onClick={toggleFollow}
                            className="follow-btn bg-primary-400 rounded-lg w-32 text-white py-1"
                        >
                            Follow
                        </button>
                    )
                ) : (
                    <button
                        disabled
                        className="follow-btn bg-slate-600 rounded-lg w-32 text-white py-1"
                    >
                        Loading...
                    </button>
                ))}
        </div>
    );
};

export default UserCard;
