/* Imports */
import fs from "fs";
import axios from "axios";

/* Definitions */
let graphQLendpoint = "https://www.alignmentforum.org/graphql";
let query = `
{
  posts(input: {terms: {meta: null, after: "1-1-2023", before: "1-1-2024"}, enableTotal: true}) {
    totalCount
    results {
      title
      user {
        username
      }
    }
  }
}
`;

let getAllAlignmentForumPosts = async () => {
	let response = await axios({
		url: graphQLendpoint,
		method: "POST",
		headers: { "Content-Type": "application/json" },
		data: JSON.stringify({ query: query }),
	})
		.then((res) => res.data)
		.then((res) => res.data); // not a typo
	//console.log(response)
	return response;
};

/* Body */
let response = await getAllAlignmentForumPosts();
console.log(response.posts.totalCount);
console.log(response.posts.results.length);
let authors = response.posts.results.map((x) => x.user.username);
let unique_authors = new Set(authors);
console.log(`Number of unique authors: ${unique_authors.length}`);
console.log(unique_authors);
