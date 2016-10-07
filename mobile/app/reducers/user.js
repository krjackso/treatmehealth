type User = {
  username: ?string,
  id: ?number,
  loggedIn: boolean,
  loginError: ?string
}

const user = (state: User = {loggedIn: false}, action: UserAction): Object => {
  switch(action.type) {
    case 'USER_LOGIN_SUCCESS':
      return {
        ...state,
        username: action.username,
        loggedIn: true,
        id: action.id,
        loginError: null
      }
    case 'USER_LOGIN_ERROR':
      return {
        ...state,
        loginError: action.error
      }
    case 'USER_SIGNUP':
      return {
        ...state,
        username: action.username,
        loggedIn: true,
        id: action.id
      }
    default: return state
  }
}

export default user
