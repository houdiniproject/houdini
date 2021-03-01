// License: LGPL-3.0-or-later

const h = require('snabbdom/h')
function view(state) {
  //if (window.parent) {window.parent.postMessage('commitchange:followup', '*');}; 

  const supp = state.infoStep.savedSupp$()
  return h('div.u-padding--10.u-centered', [
    h('h6.u-marginTop--15', I18n.t('nonprofits.donate.followup.success'))
  , supp ? h('p', `${I18n.t('nonprofits.donate.followup.receipt_info')} ${supp.email}`) : ''
  , h('hr')
  , h('p', state.thankyou_msg || `${app.nonprofit.name} ${I18n.t('nonprofits.donate.followup.message')}`)
  , h('div.u-inlineBlock.u-marginRight--10', [
      h('a.button--small.facebook.u-width--full.share-button', {
        props: {
          target: '_blank'
        , href: 'https://www.facebook.com/dialog/feed?app_id='+app.facebook_app_id +"&display=popup&caption=" + encodeURIComponent(app.campaign.name || app.nonprofit.name) + "&link="+window.location.href
        }
      }, [h('i.fa.fa-facebook-square'), ` ${I18n.t('nonprofits.donate.followup.share.facebook')}`] )
    ])
  , h('div.u-inlineBlock.u-marginLeft--10.u-marginBottom--20', [
      h('a.button--small.twitter.u-width--full', {
        props: {
          target: '_blank'
        , href: "https://twitter.com/intent/tweet?url="+window.location.href+"&via=CommitChange&text=Join me in supporting:" + (app.campaign.name || app.nonprofit.name)
        }
      }, [h('i.fa.fa-twitter-square'), ` ${I18n.t('nonprofits.donate.followup.share.twitter')}`] )
    ])
    // Show the 'finish' button only if we're in an offsite embedded modal
  , state.params$().offsite
    ? h('div', [
        h('button.button.finish', {on: {click: state.clickFinish$}}, I18n.t('nonprofits.donate.followup.finish'))
      ])
    : ''
  ])
}


module.exports = {view}
