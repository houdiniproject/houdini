
# Object Event Hooks Configurations

With those configurations, nonprofits are able to set up webhook configurations
for given events that happen to that nonprofit. As an example, a nonprofit
might want to contact a particular API A when the a supporter is created or
when a tag_master is added while they might want to contact a different API B
when a supporter is deleted.

Currently, Houdini supports sending triggers to OpenFn.

## Setup Instructions

### OpenFn side

* Navigate to [OpenFn](https://www.openfn.org/signup) and sign up;
* Set up an authentication method on `Access and Security` option, by clicking
on `Add new security protocol`. Choose the API Key auth type;
* Create a trigger of "Message Trigger" type and define which filter should be
in your trigger payload:

  ![image](https://user-images.githubusercontent.com/15739610/107866816-73daeb80-6e53-11eb-9d3b-7593a77ed6b4.png)

  > In this case, we'll be sending an event of type *supporter_note.created*.

* Navigate to the project view and copy your inbox link.

#### Creating a job that sends an e-mail using Mailgun

* Create an account on [Mailgun](https://signup.mailgun.com/new/signup) (for
the sake of testing, a free account is enough);
* For using the sandbox domain Mailgun provides for testing, add your e-mail
as an authorized recipient:

  ![image](https://user-images.githubusercontent.com/15739610/107160074-c8bdc400-6972-11eb-89d6-4fd05f9eb249.png)

* On OpenFn, set up your Mailgun credentials on `Credentials`;
* Create a new job on `Jobs`, by clicking the `+` icon and connect to the
corresponding trigger;
* Add the script that the job is going to execute on `Execution`. An example
for Mailgun could be:

``` javascript
send({
  from: '<your-email>@gmail.com',
  to: '<your-email>@gmail.com',
  subject: 'Supporter note created!',
  text: `A supporter note was created for the supporter
  ${dataValue('data.object.supporter.name')(state)} of the nonprofit
  ${dataValue('data.object.nonprofit.name')(state)}.`,
})
```

> To access your payload data from your job, you can use
`dataValue('someKey')(state)`

### Application side

For now, there is no UI for the creation of the configuration for the Object
Event Hooks. The following instructions allow the creation of the configuration
using the console:

``` bash
rails c
```

``` ruby
# Set up for the ObjectEventHookConfig
nonprofit = Nonprofit.last
webhook_service = :open_fn
object_event_type = 'supporter_note.created'
configuration = {
    headers: { 'x-api-key': <your api key> },
    webhook_url: <your inbox url>
  }
attributes = {
    webhook_service: webhook_service,
    configuration: configuration,
    object_event_types: [ object_event_type ]
  }
object_event_hook_config =
  nonprofit.object_event_hook_configs.create(attributes)
```

In the application, navigate to the nonprofit supporters' view:

![image](https://user-images.githubusercontent.com/15739610/108004367-6dc04880-6fd4-11eb-9126-6e4ed074fcbe.png)

Create a new supporter and open their details or simply open the details of an
existing one.

Click the `+ Note` button, write a note and click `Submit`.

![image](https://user-images.githubusercontent.com/15739610/108004473-b972f200-6fd4-11eb-91c2-8b6d49a1545a.png)

The OpenFn inbox is going to show a successful run for your job, and on the run
details you'll be able to see that the mail sending was enqueued, and in a few
instants, you'll have received an e-mail with the event details.

![image](https://user-images.githubusercontent.com/15739610/108004611-1a022f00-6fd5-11eb-8a76-4891826e904d.png)
> OpenFn successful run
