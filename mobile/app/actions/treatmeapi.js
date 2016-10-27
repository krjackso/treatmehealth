// @flow

import { Dispatch, State } from 'react-redux'
import base64 from '../util/base64'
import { showLogin } from './ui'
import { getAuth } from '../reducers/auth'
import { getApi } from '../reducers/api'

const BOOTSTRAP_URL = "http://localhost:8080/api/bootstrap"

function authenticatedRequest(url: string, opts: Object, dispatch: Dispatch, getState: Function): Promise<Response> {
  let optsCopy = opts.clone()

  let auth = getAuth(getState())
  let api = getApi(getState())
  optsCopy.headers['Authorization'] = 'Bearer ' + auth.accessToken

  return fetch(url, optsCopy).then((res) => {
    if (res.status == 401) {
      return refreshAuth(api, auth.username, auth.refreshToken).then( (res) => {
        if (res.ok) {
          dispatch(authSuccess(res.accessToken, res.refreshToken, res.id))
        } else {
          dispatch(showLogin())
        }
      })
    } else {
      return res
    }
  })
}

const bootstrap = () => {
  let request = new Request(BOOTSTRAP_URL)

  return fetch(request).then((res) => res.json())
}

const refreshAuth = (api: Object, username: string, refreshToken: string): Promise<Response> => {
  let auth = base64.encode(username + ':' + refreshToken)

  let request = new Request(api.refreshAuth, {
    method: 'POST',
    headers: {
      Authorization: 'Basic ' + auth
    },
    body: JSON.stringify({
      refreshToken: refreshToken
    })
  })

  return fetch(request).then((res) => res.json())
}

const signUp = (links: Object, username: string, email: string, password: string, zip: string, dob: Date): Promise<Response> => {
  let request = new Request(links.register, {
    method: 'PUT',
    body: JSON.stringify({
      username: username,
      email: email,
      password: password,
      zip: zip,
      dob: dob
    })
  })

  return fetch(request).then((res) => res.json())
}

const login = (links: Object, username: string, password: string): Promise<Response> => {
  let auth = base64.encode(username + ':' + password)

  let request = new Request(links.login, {
    method: 'POST',
    headers: {
      Authorization: 'Basic ' + auth
    }
  })

  return fetch(request).then((res) => {
    if (res.ok) {
      return res.json()
    } else if (res.status == 401) {
      return Promise.reject("Invalid username or password")
    } else {
      return Promise.reject("Sorry, we encountered an error")
    }
  })
}

export default {
  bootstrap,
  refreshAuth,
  signUp,
  login
}
