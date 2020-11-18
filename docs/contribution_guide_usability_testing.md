# Usability Testing Contribution Guide

A usability test is a UX research methodology for evaluating user interfaces,
being those paper prototypes, high-fidelity prototypes, a live version of a
software, and so on. The basic procedure consists of having a **moderator** or
**facilitator** watching representative users performing significant tasks in
the interface to understand their thoughts and reporting the results.

Usability tests are widely recommended in order to have information not only
about whether users are failing to complete the tasks or not, but also why are
they failing, which is useful to have conclusions on how the interface should be
improved.

The user testing process consists of three main steps:

1. Designing the test;
2. Running the test sessions;
3. Reporting test results.

## 1. Designing the test

To design your test, start by creating an issue on the project to follow the
test template.

Decide on what needs to be tested, the **objective** of the test. It can be a
user journey, an application feature, or something as small as understanding
what a specific button does. If you have many objectives, prefer to write more
than one test instead of running one big test. Short sessions of 15 minutes or
less are better so as not to tire participants.

### Requirements

For the test sessions to happen, there might be a couple of requirements that
need to be described beforehand:

* **User profile** - the users for the tests should be representative of the
  application  domain;
* **Environment** - how should the environment be prepared, from the version of
  the  application to other details like populating the database with previous
  data or starting at a specific part of the application;
* **Facilitator** - what the facilitator needs to know to run the test session.
  For example, a volunteer to be a facilitator can't run a test session for a
  git GUI without understanding how git works.

### Tasks

Prepare a list of significant **tasks** that the users need to perform in the
interface. A task itself does not contain details concerning context, it will
be used to build the scenario tasks and can be useful as a guide to reporting
results later.

### Scenarios

Scenarios are the test script for the users. Using the **tasks**, describe
relatable scenarios for the test session. Make sure to write them as if the
user would be in the context of the application usage. Place the scenarios in an
order that makes sense in the software journey.

Not giving hints while choosing the words used in the scenarios descriptions is
as important as creating well described and contextualized scenarios. Avoid
suggesting button names, or naming any kind of element in the interface to
instigate users to figure out themselves where should they click.

A badly written scenario would be:

> :x:
>
> Edit your profile picture to a newer one.

This scenario is not well contextualized. In case the button for editing the
profile picture is called "Edit", it suggests where the user should click.

For this situation, a good example of a scenario could be:

> :heavy_check_mark:
>
> You received an e-mail asking you to update your personal information because
> your profile picture is outdated. Please, look for this option in the
> application.

This scenario puts a reason for doing the action on the application and does not
suggest the user click on "Edit" instantly.

Once you have finished designing your test, test the test: review it by running
the test like you expect the users to do. This is important to check if the
test flow and tasks make sense.

## 2. Running the test sessions

### Users

Find some users accordingly to the requirements. Usually, 5 users are enough for
a test iteration, but you can contribute with as many users as you can or want
to. Collect some data from the users, like their familiarity with similar
software, or their technical background: it can be useful later to evaluate
results.

### Preparation

Set the environment up like described on the test requirements. Run the test
like it is expected from the users, so that you'll know what you have to pay
attention to.

Start the session by providing context to the user on what the software is about
and what the tests are for. It's a good idea to ask the user permission to
record the session so that you can focus on observing the task execution and
rewatch the session later or show the videos to the software designers.

Encourage the user to think aloud, telling what they are looking for, what they
are trying to do, to help you follow their rationale. It is common that
sometimes they forget to think aloud, so you can ask questions about what they
are doing to remind them.

Explain how the session is going to be, and make it clear for the user that what
is being tested is the software, not their knowledge or technology skills, so
if they fail, it's the interface fault. Allow them to give up on a task if they
are stuck and can't figure it out.

Explicitly tell the user that you expect them to be honest and that you won't be
offended if the interface is not good.

### Test execution

For each scenario, read it aloud to the user and watch they interact with the
interface. Don't give hints, let the user try on their own. If they ask
questions, guide them with other questions, be careful not to bias the test
result by helping the user.

After each scenario, you can ask some follow-up questions to gather some
information that may come up only when the task is finished, like "where were
you expecting to find that button first?", "which icon were you looking for?".

## 3. Reporting results

Add your results to the corresponding issue comments. Once all the tests are
finished, add the conclusions to the issue template.

Reporting the results well is essential for addressing usability problems and
having useful insight to make improvements, especially when other people are
going to read the report to work on the next design version. Write about what
went well and what were the challenges, describe how the users felt, what did
they try and why.

<!-- markdownlint-disable MD028 -->
> What went well?
>
> Users intuitively clicked on the "?" icon to find the help documentation.

> What were the challenges?
>
> Some users didn't understand how to create a new blog post inside a folder,
> they first created the post and then edited the folder to include the post
> inside of it. They said they were looking for a select input to choose where
> the blog post should be placed instead of a folder icon.
<!-- markdownlint-enable MD028 -->

Use screenshots to illustrate better your description, GIFs, or videos.

### Summarizing results

To have an overview of the test results, you can use a table that illustrates
where users failed or went well. Having a summarized version of the results
also helps to track improvements in the interface for tests being run
iteratively.

Use a table with rows corresponding to tasks and columns to users. Write an :x:
where users failed and a :heavy_check_mark: where they were able to complete
the task. When in doubt, use a :question: symbol.

<!-- markdownlint-disable MD013 -->
|   -    | User 1 | User 2 | User 3 | User 4 | User 5 |
|:------:|:------:|:--------:|:------------------:|:------:|:------:|
| Task 1 | :x:    | :question: | :heavy_check_mark: | :x: | :heavy_check_mark: |
| Task 2 | :heavy_check_mark:    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Task 3 | :heavy_check_mark:    | :heavy_check_mark: | :x: | :heavy_check_mark: | :heavy_check_mark: |
| Task 4 | :heavy_check_mark:    | :question: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Task 5 | :heavy_check_mark:    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| Task 6 | :x:    | :heavy_check_mark: | :heavy_check_mark: | :x: | :heavy_check_mark: |
| Task 7 | :heavy_check_mark:    | :x: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
