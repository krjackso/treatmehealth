import React, { Component } from 'react'
import { View, Text } from 'react-native'

export default class Profile extends Component {
  render() {
    return (
      <View>
        <Text>Hello {this.props.username}, this is the Profile Screen</Text>
      </View>
    )
  }
}
