from typing import Generic, TypeVar, Optional
from pydantic import BaseModel
from pydantic.generics import GenericModel

T = TypeVar("T")

class ApiResponse(GenericModel, Generic[T]):
    code: int
    message: str
    data: Optional[T] = None

    @staticmethod
    def success(data: Optional[T] = None):
        return ApiResponse(code=200, message="Success", data=data)

    @staticmethod
    def error(code: int, message: str):
        return ApiResponse(code=code, message=message, data=None)