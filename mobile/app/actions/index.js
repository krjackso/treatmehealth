import { Dispatch, State } from 'react-redux'
import TreatMe from './treatmeapi'
import { checkAuth } from './auth'

export const API_BOOTSTRAP = "API_BOOTSTRAP"

export const bootstrap = () => (dispatch: Dispatch) => {
  return TreatMe.bootstrap().then((links) => {
    console.log(links)
    dispatch({
      type: API_BOOTSTRAP,
      links
    })
    dispatch(checkAuth())
  })
}
