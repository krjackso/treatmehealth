package authutil

import (
	"context"
)

const (
	userIdKey = "userId"
)

func ContextWithUserId(ctx context.Context, userId int64) context.Context {
	return context.WithValue(ctx, userIdKey, userId)
}

func UserIdFromContext(ctx context.Context) int64 {
	userId := ctx.Value(userIdKey).(int64)
	return userId
}
