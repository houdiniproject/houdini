# Translating Houdini

We use [Crowdin](https://crowdin.com/project/houdiniproject) to work on our translations. Not all Houdini's pages and components are translatable, we are working on making Houdini entirely translatable, and you can help us with that too!

## Getting started

If you want to help Houdini with translations, you can do it by using our [Crowdin](https://crowdin.com/project/houdiniproject) to add your translations (see [Translating strings using Crowdin](#translating-strings-using-crowdin)).

If a page, component, or string is not available on Crowdin to be translated yet, you're going to need to follow the [Making a component translatable](#making-a-component-translatable) guide to creating the source translation file if needed or add the keys to a source translation file and add support to i18n to the component before adding translations to another language.

If there's a translation that you'd like to change, take a look at the [Modifying translations](#modifying-translations) topic.

## Translating strings using Crowdin

> To translate strings, they need to be available in Crowdin. If they are not yet, you can help us by making them translatable by following [this guide](#making-a-component-translatable) and then translating them to the language that you want.

1. From [Crowdin](https://crowdin.com/project/houdiniproject) main page, select the language to which you want to translate.

> Note: If the language still doesn't exist on Crowdin, you can request that a language gets added by [filing an issue](https://github.com/houdiniproject/houdini/issues/new?assignees=&labels=enhancement&template=language_request.md&title=%5BFEATURE%5D).

2. Pick a file that you want to translate.

3. Translate the strings and save.

When your translations get approved, they will be automatically submitted to Houdini's repo.

You can read further about Crowdin's translation editor on [their website](https://support.crowdin.com/online-editor/). You'll be notified when new strings to be translated are added to the project.

## Making a component translatable

Some components are still not translatable using i18n, as they are used in plain text on the view files.

To enable translations on a page, we need to follow the steps below:

1. Identify the strings that you want to make translatable.

Every significant component needs to have its translation name. For example, [app/views/roles/_new_modal.html.erb](app/views/roles/_new_modal.html.erb)'s translations were named as `roles.new`, as they refer to creating a new role.

We can also have translations for strings that are shared in multiple components. For example, [config/locales/en/ui.yml](config/locales/en/ui.yml) holds UI strings that can be shared between multiple components, such as common button labels or links.

2. If **the translation files already exist** for the strings you want to make translatable (given the context and the organization of the files), **you can work on those files and go to step 4.**

Example:

```yml
en:
  roles:
    new:
      invite_a_new_user: Invite a New User
      nonprofit_admin: Nonprofit Admin
      ...
```

3. If **the translation files don't exist yet** for the strings that you want to make translatable, then you need to create new source files in English. The name of the translation file should be the same as the component name, followed by the `.yml` extension. It should be placed under `config/locales/en`. For example, [app/views/roles/_new_modal.html.erb](app/views/roles/_new_modal.html.erb)'s translation file is named as `roles.new.yml`.

Example:

```yml
en:
  roles:
    new:
      invite_a_new_user: Invite a New User
      nonprofit_admin: Nonprofit Admin
      ...
```

4. Find every string that is going to be translated, create a key for it and place it into your translation file.

It's important to give it a well-detailed name so that when someone is reading the code on the component they automatically understand what that string is without having to look at the translation file.

For example, the text `Full permissions, including bank payouts` on [roles.new.yml](config/locales/en/roles.new.yml), as big as it is, has the key `full_permissions_including_bank_payouts`.

5. Replace the strings from the components with their corresponding keys.

Examples:

* On .erb files, you should replace the "Full permissions, including bank payouts" text for `t('roles.new.full_permissions_including_bank_payouts')`;
* For `.tsx` files, you should import the `useIntl` hook from the `intl` component and import `formatMessage` from it. You should then create a constant with `formatMessage({ id: 'roles.new.full_permissions_including_bank_payouts' })` and replace the text by the name of the constant you created - you can look at how it's done on our [SignInComponent.tsx](https://github.com/houdiniproject/houdini/blob/a31e755f1bdf21c5c894018fe8ec3b26fcf6c896/app/javascript/components/users/SignInComponent.tsx#L77);
* For `.js` or `.es6` files, replace the text with `I18n.t('roles.new.full_permissions_including_bank_payouts')`.

6. Commit the changes and open a pull request to Houdini/main.

7. When your pull request is merged, after up to 1 hour, Crowdin is going to sync the new file and make it available for translations. Once the file is synced, you can start translating from Crowdin.

## Modifying translations

You can use the Crowdin editor to modify translations. Just like when you add a new translation, when you add a new translation for a file that was already translated before, it is going to be submitted for approval again.

In case you think a key needs to be changed instead of a translation, add the new key directly on the source file. Keep both keys and submit the pull request. Once the new key is synced to Crowdin, the old key translations are going to be copied over to the new key. On Houdini's code, find and replace every occurrence of the old key with the new key, and remove the old key from the source translation file. Submit a pull request with those changes, once everything is synced the code should now be using the new key.

If a key is no longer needed, remove it from the source translation file and make sure that there's no occurrence of it in the code and submit a pull request.

If you want to delete an entire translation file, make sure none of its keys are used in the code. If the keys are being placed in another file, the keys should be added to the other files and submitted before deleting the file. After the code is referencing the new keys and the translations are updated on Crowdin, you can delete the file and submit a new PR.
