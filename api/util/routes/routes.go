package routes

import (
	"strconv"
)

const (
	Domain = "http://localhost:8080"
	Base   = "/api"

	GetUser              = "/users/:id"
	PutUser              = "/users"
	Login                = "/auth/login"
	Logout               = "/auth/logout"
	RefreshAuth          = "/auth/refresh"
	CheckAuth            = "/auth"
	RequestPasswordReset = "/auth/resetPassword"
)

func Absolute(withoutBase string) string {
	return Domain + Base + withoutBase
}

func HyperGetUser(userId int64) string {
	return Absolute("/users/" + strconv.FormatInt(userId, 10))
}
