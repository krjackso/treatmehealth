package util

import (
	"time"
)

const (
	dateLayout = "1/2/2006"
)

func ParseDate(dateString string) (time.Time, error) {
	return time.Parse(dateLayout, dateString)
}
