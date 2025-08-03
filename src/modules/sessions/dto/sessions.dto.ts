import { IsString, IsOptional, MinLength, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateSessionDto {
  @ApiProperty({ 
    example: 'My Chat Session',
    description: 'Session title',
    minLength: 1,
    maxLength: 500,
    default: 'New Chat'
  })
  @IsString()
  @MinLength(1)
  @MaxLength(500)
  title: string;

  @ApiProperty({ 
    example: 'This is a chat session about AI topics',
    description: 'Session description',
    required: false,
    maxLength: 1000
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  description?: string;
}

export class RenameSessionDto {
  @ApiProperty({ 
    example: 'Updated Session Title',
    description: 'New session title',
    minLength: 1,
    maxLength: 500
  })
  @IsString()
  @MinLength(1)
  @MaxLength(500)
  title: string;
} 