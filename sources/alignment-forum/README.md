## Example query
{
      posts(input: {
        terms: {
          view: "top"
          limit: 50
          meta: null  # this seems to get both meta and non-meta posts
        }
      }) {
        results {
          title
        }
      }
}

See also:

 {
  post(
    input: {  
      selector: {
        _id: "EZq4pBEGfdccEec3W"
      }      
    }) 
  {
    result {
      _id
      title
      slug
      pageUrl
      postedAt
      baseScore
      voteCount

      meta
      question
      url
      user {
        username
        slug
        karma
      }
    }
  }
}


## Convert to pdf

In the text, replace \" with ", so that links work

Query to get one particular post:

 {
      post(input: {
        selector:{
          _id: "ZyWyAJbedvEgRT2uF"
        }
      }) {
        result {
          htmlBody
        }
      }
    }




---	
title: Inaccessible Information
author: Paul F. Christiano
date: 3rd of June 2020
urlcolor: blue
---


Transform to markdown, add the title, then transform the pdf. 

https://www.lesswrong.com/posts/LJiGhpq8w4Badr5KJ/graphql-tutorial-for-lesswrong-and-effective-altruism-forum


To change image size: ![](file.jpg){ width=50% }
See also: https://pandoc.org/MANUAL.html

https://www.lesswrong.com/graphiql

## Query for Monthly posts.


{
      posts(input: {
        terms: {
          # view: "top"
          meta: null  # this seems to get both meta and non-meta posts
          after: "10-1-2020"
          before: "11-2020"
        }
      }) {
        results {
          title
          url
          pageUrl
        }
      }
}

Then save this into a .txt file, and apply

grep "title\|url\|pageUrl" temp.txt | sed 's/^.*: //' | sed '0~3 a\\' | sed 's/\"//g' > tempclean.txt

## Get all posts
{
      posts(input: {
        terms: {
          # view: "top"
          meta: null  # this seems to get both meta and non-meta posts
          after: "10-1-2000"
          before: "10-11-2020" # or some date in the future
        }
      }) {
        results {
          title
          pageUrl
          createdAt
        }
      }
}
