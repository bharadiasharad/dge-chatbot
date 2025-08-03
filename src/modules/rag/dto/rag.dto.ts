import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RagChatDto {
  @ApiProperty({
    example: 'What is artificial intelligence?',
    description: 'Message to send to RAG system'
  })
  @IsString()
  message: string = '';
}

export class RagQueryDto {
  @ApiProperty({
    example: 'machine learning algorithms',
    description: 'Query to search documents'
  })
  @IsString()
  query: string = '';
} 