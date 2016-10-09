import React, { Component } from 'react'
import { View, TouchableWithoutFeedback } from 'react-native'
import dismissKeyboard from 'dismissKeyboard'

export default class HideKeyboard extends Component {
  render() {
    return (
      <TouchableWithoutFeedback onPress={dismissKeyboard} >
        {this.props.children}
      </TouchableWithoutFeedback>
    )
  }
}
