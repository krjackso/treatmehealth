// @flow

import { Dispatch } from 'react-redux'
import { showProfile } from './ui'

export const USER_UPDATED = 'USER_UPDATED'

export const setUser = (user: Object) => (dispatch: Dispatch) => {
  dispatch({
    type: USER_UPDATED,
    user
  })

  console.log("setUser", user)

  if (!user.profileComplete) {
    dispatch(showProfile(user.username))
  }
}
