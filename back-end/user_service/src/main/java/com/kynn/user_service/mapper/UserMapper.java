package com.kynn.user_service.mapper;

import com.kynn.user_service.dto.resonse.UserDTO;
import com.kynn.user_service.entity.User;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface UserMapper {

  UserDTO toDTO(User user);

  User toUser(UserDTO userDTO);
}
