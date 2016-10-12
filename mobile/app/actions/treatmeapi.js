// @flow

import { Dispatch, State } from 'react-redux'
import base64 from '../util/base64'

const API_URL = "http://localhost:8080/api"

const refreshAuth = (refreshToken: string): Promise<Response> => {
  let request = new Request(API_URL + '/auth/refresh', {
    method: 'POST',
    body: JSON.stringify({
      refreshToken: refreshToken
    })
  })

  return fetch(request).then((res) => res.json())
}

const signUp = (username: string, email: string, password: string, zip: string, dob: Date): Promise<Response> => {
  let request = new Request(API_URL + '/users', {
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

const login = (username: string, password: string): Promise<Response> => {
  let token = base64.encode(username + ':' + password)

  let request = new Request(API_URL + '/auth/login', {
    method: 'POST',
    headers: {
      Authorization: 'Basic ' + token
    }
  })
  
  return fetch(request).then((res) => res.json())
}

export default {
  refreshAuth,
  signUp,
  login
}
